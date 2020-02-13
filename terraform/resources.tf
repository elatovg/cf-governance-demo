/*
Copyright 2019 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

///////////////////////////////////////////////////////////////////////////////////////
// This configuration will create an object in a specified storage bucket and make it
// public
///////////////////////////////////////////////////////////////////////////////////////

resource "google_storage_bucket_object" "pub-object" {
  name   = "file.txt"
  content = "Test File"
  bucket = "${var.storage-bucket}"
}

resource "google_storage_object_acl" "object-store-acl" {
  bucket = "${var.storage-bucket}"
  object = "${google_storage_bucket_object.pub-object.name}"

  role_entity = [
    "READER:allUsers",
  ]
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "${var.storage-bucket}"
  role   = "roles/storage.objectViewer"

  members = [
    "group:allUsers",
  ]
}