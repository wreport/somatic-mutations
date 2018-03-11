workflow mutect2_workflow {
    File bam
    File reference
    String results_folder

    call mutect2_task as mutect2_call {
        input:
            bam = bam,
            reference = reference
    }
    call copy_task as copy_call {
        input:
            files = mutect2_call.out,
            destination = results_folder
    }
}

task mutect2_task {
    File bam
    File reference

    command {
        gatk \
        Mutect2 \
        -R ${reference} \
        -I:${bam} \
        --artifact_detection_mode \
        -o variants.vcf
    }

    runtime {
        docker: "broadinstitute/gatk@sha256:fd8e7a9e65e6a981ab3b92305492d54c3baef7a803ec3fcb895e5ebeedf824e7"
      }

    output {
        File out = "variants.vcf"
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
