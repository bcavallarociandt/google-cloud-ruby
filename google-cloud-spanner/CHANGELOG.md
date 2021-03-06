# Release History

### 0.22.0 / 2017-07-11

* Remove `Policy#deep_dup`.
* Add thread pool size to `Session` pool configuration.
* Add error handling for some GRPC errors.
* Do not allow nested snapshots or transactions.
* Update initialization to raise a better error if project ID is not specified.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update example code in the API documentation and guide.

### 0.21.0 / 2017-06-08

Initial implementation of the Google Cloud Spanner API Ruby client.
