workflow picsam_workflow {

    File reference
    String results_folder

    call picard_task as picard_call {
        input:
            reference = reference
    }
    call copy_task as picard_copy_call {
        input:
            files = picard_call.out,
            destination = results_folder
    }
    call samtools_task as samtools_call {
        input:
            reference = reference
    }
    call copy_task as samtools_copy_call {
        input:
            files = samtools_call.out,
            destination = results_folder
    }
}

task picard_task {
    File reference

    command {
        picard CreateSequenceDictionary \
        R= ${reference} \
        O= GRCh38.p10.genome.fa.dict
    }

    runtime {
        docker: "biocontainers/picard@sha256:1dc72c0ffb8885428860fa97e00f1dd868e8b280f6b7af820a0418692c14ae00"
      }

    output {
        File out = "GRCh38.p10.genome.fa.dict"
      }

}

task samtools_task {
    File reference

    command {
        samtools \
        faidx \
        ${reference} \
    }

    runtime {
        docker: "biocontainers/samtools@sha256:fbda13f53abb21ffb5859492c063c13cc3d9b7b5f414b1c31ccc2a48109abfee"
      }

    output {
        File out = "GRCh38.p10.genome.fa.fai"
      }

}

task copy_task {
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
