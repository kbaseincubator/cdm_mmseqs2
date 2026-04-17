FROM soedinglab/mmseqs2:latest

# CTS requires an entrypoint
ENTRYPOINT ["mmseqs"]
