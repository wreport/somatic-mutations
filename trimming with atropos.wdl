call atropos_illumina_trim {
      input:
        reads_1 = reads_1,
        reads_2 = reads_2,
	adapter_1 = adapter_1,
	adapter_2 = adapter_2,
        threads = threads
  }

task atropos_illumina_trim {
  File reads_1
  File reads_2
  Int threads

  command {
    atropos trim \
      --aligner insert \
      -a ${adapter_1} \
      -A ${adapter_2} \
      -pe1 ${reads_1} \
      -pe2 ${reads_2} \
      -o ${basename(reads_1, ".fastq.gz")}_trimmed.fastq.gz \
      -p ${basename(reads_2, ".fastq.gz")}_trimmed.fastq.gz \
      --threads ${threads} \
      --stats both \
      --report-file ${reads_1}_${reads_2}_report \
      --report-formats txt json \
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

