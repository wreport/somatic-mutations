workflow atropos_illumina_trim_workflow{
    File reads_1
    File reads_2
    Int threads
    String adapter_1
    String adapter_2
    String results_folder

    call report as initial_report_1_call {
      input:
        sampleName = basename(reads_1, ".fastq.gz"),
        file = reads_1
      }

    call report as initial_report_2_call {
      input:
        sampleName = basename(reads_2, ".fastq.gz"),
        file = reads_2
      }

    call atropos_illumina_trim_task as atropos_illumina_trim_call {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
        adapter_1 = adapter_1,
        adapter_2 = adapter_2,
        threads = threads
    }

    call report as final_report_1_call {
        input:
          sampleName = basename(atropos_illumina_trim_call.out1, ".fastq.gz"),
          file = atropos_illumina_trim_call.out1
        }

    call report as final_report_2_call {
        input:
          sampleName = basename(atropos_illumina_trim_call.out2, ".fastq.gz"),
          file = atropos_illumina_trim_call.out2
        }

  call copy as copy_trimmed {
    input:
        files = [atropos_illumina_trim_call.out1, atropos_illumina_trim_call.out2],
        destination = results_folder + "/trimmed/"
  }

  call copy as copy_initial_quality_reports {
    input:
        files = [initial_report_1_call.out, initial_report_2_call.out],
        destination = results_folder + "/quality/initial/"
  }

  call copy as copy_cleaned_quality_reports {
    input:
        files = [final_report_1_call.out, final_report_2_call.out],
        destination = results_folder + "/quality/cleaned/"
  }

  call multiqc_report {
    input:
        last_reports = copy_cleaned_quality_reports.out,
        folder = results_folder,
        report = "reports"
  }

  call copy as copy_multiqc_report {
      input:
          files = [multiqc_report.out],
          destination = results_folder
    }


  output {
    Array[File] out = copy_multiqc_report.out
  }

}


task atropos_illumina_trim_task {
  File reads_1
  File reads_2
  Int threads
  String adapter_1
  String adapter_2

  command {
    atropos trim \
    -a ${adapter_1} \
    -A ${adapter_2} \
    -pe1 ${reads_1} \
    -pe2 ${reads_2} \
    -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq.gz \
    -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq.gz \
    --minimum-length 35 \
    --aligner insert \
    -q 18 \
    -e 0.1 \
    --threads ${threads} \
    --correct-mismatches liberal
  }

  runtime {
    docker: "jdidion/atropos@sha256:c2018db3e8d42bf2ffdffc988eb8804c15527d509b11ea79ad9323e9743caac7"
  }

  output {
    File out1 = basename(reads_1, ".fastq.gz") + "_trimmed.fastq.gz"
    File out2 = basename(reads_2, ".fastq.gz") + "_trimmed.fastq.gz"
  }
}

task report {

  String sampleName
  File file

  command {
    /opt/FastQC/fastqc ${file} -o .
  }

  runtime {
    docker: "quay.io/ucsc_cgl/fastqc@sha256:86d82e95a8e1bff48d95daf94ad1190d9c38283c8c5ad848b4a498f19ca94bfa"
  }

  output {
    File out = sampleName+"_fastqc.zip"
  }
}


task multiqc_report {

   File folder
   String report
   Array[File] last_reports #just a hack to make it wait for the folder to be created

   command {
        multiqc ${folder} --outdir ${report}
   }

   runtime {
        docker: "quay.io/comp-bio-aging/multiqc@sha256:20a0ff6dabf2f9174b84c4a26878fff5b060896a914d433be5c14a10ecf54ba3"
   }

   output {
        File out = report
   }
}

task copy {
    Array[File] files
    String destination

    command {
        mkdir -p ${destination}
        cp -L -R -u ${sep=' ' files} ${destination}
    }

    output {
        Array[File] out = files
    }
}
