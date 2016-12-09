/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.fs.s3a;

import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.contract.ContractTestUtils;
import org.junit.Test;

import java.io.IOException;

/**
 * Tests which exercise treatment of empty/non-empty directories.
 */
public class ITestS3AEmptyDirectory extends AbstractS3ATestBase {

  @Test
  public void testDirectoryBecomesEmpty() throws Exception {
    S3AFileSystem fs = getFileSystem();

    // 1. set up non-empty dir
    Path dir = path("testEmptyDir");
    Path child = path("testEmptyDir/dir2");
    mkdirs(child);

    S3AFileStatus status = getS3AFileStatus(fs, dir);
    assertFalse("Dir status should not be empty", status.isEmptyDirectory());

    // 2. Make testEmptyDir empty
    assertDeleted(child, false);
    status = getS3AFileStatus(fs, dir);

    assertTrue("Dir status should be empty", status.isEmptyDirectory());
  }

  @Test
  public void testDirectoryBecomesNonEmpty() throws Exception {
    S3AFileSystem fs = getFileSystem();

    // 1. create empty dir
    Path dir = path("testEmptyDir");
    mkdirs(dir);

    S3AFileStatus status = getS3AFileStatus(fs, dir);
    assertTrue("Dir status should be empty", status.isEmptyDirectory());

    // 2. Make testEmptyDir non-empty

    ContractTestUtils.touch(fs, path("testEmptyDir/file1"));
    status = getS3AFileStatus(fs, dir);

    assertFalse("Dir status should not be empty", status.isEmptyDirectory());
  }

  private S3AFileStatus getS3AFileStatus(S3AFileSystem fs, Path p) throws
      IOException {
    FileStatus s = fs.getFileStatus(p);
    assertTrue(s instanceof S3AFileStatus);
    return (S3AFileStatus)s;
  }

}
