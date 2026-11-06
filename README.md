# cdm_mmseqs2

CTS (CDM Task Service) job wrapper for [MMseqs2](https://github.com/soedinglab/MMseqs2) sequence clustering and search.

## Container

Wraps the official [`soedinglab/mmseqs2`](https://hub.docker.com/r/soedinglab/mmseqs2) image.
Published to `ghcr.io/kbaseincubator/cdm_mmseqs2`.

**Entrypoint:** `mmseqs` (no subcommand): append the desired subcommand as the first argument
(e.g. `easy-cluster`, `easy-search`, `easy-linclust`).

**Refdata:** Not required for clustering modes (`easy-cluster`, `easy-linclust`).
Required for search modes (`easy-search`) which need a pre-built reference database.

## Usage via CTS

See the [CTS documentation](https://github.com/kbase/cdm-task-service) and the demo notebook
at `global_share/jplfaria/mmseqs2_demo.ipynb` on hub.berdl.kbase.us.

### Example: easy-cluster (all-vs-all, no refdata)

```python
job = tscli.submit_job(
    "ghcr.io/kbaseincubator/cdm_mmseqs2:0.1.0@sha256:24afa107c0dac1a6f093cc081ec19a577c4d0b156dfa8ee66bb2d3c41b97c082",
    input_files,
    "cts/io/jplfaria/output/mmseqs2/test/v1",
    cluster="kbase",
    declobber=True,
    output_mount_point="/out",
    args=[
        "easy-cluster",
        tscli.insert_files(),
        "/out/cluster_results",
        "/tmp/mmseqs",
        "--threads", "8",
    ],
    num_containers=1,
    cpus=8,
    memory="32GB",
    runtime="PT30M"
)
```

What the arguments mean:

- `input_files`: a list of MinIO paths (`bucket/key`) to FASTA files, e.g.
  `["cts/io/<you>/inputs/genome_a.faa", "cts/io/<you>/inputs/genome_b.faa"]`. Upload your files
  to MinIO first. CTS stages them into the container, and `tscli.insert_files()` expands to their
  in-container paths at that position in `args`.
- `"cts/io/jplfaria/output/mmseqs2/test/v1"`: where CTS uploads results in object storage when the job
  finishes. The bucket is `cts`; write under your own prefix, `cts/io/<your username>/...`. Everything
  after that is free-form.
- `output_mount_point="/out"`: the directory inside the container that CTS collects and uploads.
  The tool must write its results under `/out`.
- `/tmp/mmseqs`: MMseqs2's scratch directory. Keep it **outside** `/out`, otherwise the
  intermediate files are uploaded alongside the results.
- `num_containers=1`: keep all inputs in one container. With more containers, each one clusters only its own subset of files and the job still succeeds, giving separate clusterings instead of one.
- `declobber=True`: CTS puts each container's output under its own numbered subdirectory so
  parallel containers cannot overwrite each other. With one container, results land under `0/`,
  e.g. `cts/io/jplfaria/output/mmseqs2/test/v1/0/cluster_results_cluster.tsv`.

## Output

- `cluster_results_cluster.tsv`: representative -> member mapping (lakehouse importer: open PR #35 in kbase/cdm-spark-events-importers)
- `cluster_results_rep_seq.fasta`: representative sequences
- `cluster_results_all_seqs.fasta`: all sequences
