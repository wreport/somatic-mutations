workflow samtools_workflow {
    File sam
    String results_folder

    call samtools_task as samtools_call {
        input:
            sam = sam
    }
    call copy_task as copy_call {
        input:
            files = samtools_call.out,
            destination = results_folder
    }
}

task samtools_task {
    File sam

    command {
        samtools \
        view \
        -bS \
        ${sam} \
        > aln.bam
    }

    runtime {
        docker: "biocontainers/samtools@sha256:fbda13f53abb21ffb5859492c063c13cc3d9b7b5f414b1c31ccc2a48109abfee"
      }

    output {
        File out = "aln.bam"
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
