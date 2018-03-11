workflow minimap2_workflow {
    File reads_1
    File reads_2
    File reference

    call minimap2_task as minimap2_call {
        input:
            reads_1 = reads_1,
            reads_2 = reads_2,
            reference = reference
    }
}

task minimap2_task {
    File reads_1
    File reads_2
    File reference

    command {
        minimap2 \
        -ax \
        sr \
        -L \
        ${reference} \
        ${reads_1} \
        ${reads_2} \
        > aln.sam
    }

    runtime {
        docker: "genomicpariscentre/minimap2@sha256:536d7cc40209d4fd1b700ebec3ef9137ce1d9bc0948998c28b209a39a75458fa"
      }

}
