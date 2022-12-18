package com.eightaugusto.cli.example;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.*;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import picocli.CommandLine;

public class CheckSumTest {

  private static final int SUCCESS_CODE = 0;

  @Test
  @DisplayName("When calculate checksum expect response")
  public void when_calculate_checksum_expect_response() throws IOException {
    File file = null;
    try {
      // Create and write the file
      final String fileName = UUID.randomUUID().toString();
      file = new File(fileName);
      final FileWriter fileWriter = new FileWriter(file);
      fileWriter.write(fileName);
      fileWriter.close();

      // Get the checksum
      final CheckSum checkSum = new CheckSum();
      final StringWriter stringWriter = new StringWriter();
      final CommandLine commandLine = new CommandLine(checkSum);
      commandLine.setOut(new PrintWriter(stringWriter));

      // Assert the output
      assertEquals(SUCCESS_CODE, commandLine.execute(fileName));
      assertNotNull(stringWriter.toString());
    } finally {
      Optional.ofNullable(file).ifPresent(File::delete);
    }
  }
}
