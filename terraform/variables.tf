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

/*
Required Variables
These must be provided at runtime.
*/

variable "region" {
  description = "The region in which to create Demo"
  type        = "string"
}

variable "project" {
  description = "The name of the project in which to create the demo."
  type        = "string"
}

variable "storage-bucket" {
  description = "Name of storage bucket to create the object in"
  type        = "string"
  default     = "your-default-bucket"
}
