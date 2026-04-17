# cdm_mmseqs2

CTS (CDM Task Service) job wrapper for [MMseqs2](https://github.com/soedinglab/MMseqs2) sequence clustering and search.

## Container

Wraps the official [`soedinglab/mmseqs2`](https://hub.docker.com/r/soedinglab/mmseqs2) image.
Published to `ghcr.io/kbaseincubator/cdm_mmseqs2`.

## Usage via CTS

See the [CTS documentation](https://github.com/kbase/cdm-task-service) and the demo notebook
at `global_share/jplfaria/mmseqs2_demo.ipynb` on hub.berdl.kbase.us.

### Example: easy-cluster

```python
job = tscli.submit_job(
    "ghcr.io/kbaseincubator/cdm_mmseqs2:0.1.0@sha256:<digest>",
    input_files,
    "cts/io/jplfaria/output/mmseqs2/test/v1",
    cluster="kbase",
    declobber=True,
    output_mount_point="/out",
    args=[
        "easy-cluster",
        tscli.insert_files(),
        "/out/cluster_results",
        "/out/tmp",
        "--threads", "8",
    ],
    cpus=8,
    memory="32GB",
    runtime="PT30M"
)
```

## Output

- `cluster_results_cluster.tsv` — representative → member mapping (imported to Delta Lake)
- `cluster_results_rep_seq.fasta` — representative sequences
- `cluster_results_all_seqs.fasta` — all sequences
