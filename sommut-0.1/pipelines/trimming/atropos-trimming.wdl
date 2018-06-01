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


  call copy as copy_initial_quality_reports {
    input:
        files = [initial_report_1_call.out, initial_report_2_call.out],
        destination = results_folder + "/quality/initial/"
  }

  call multiqc_report {
    input:
        last_reports = copy_initial_quality_reports.out,
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
