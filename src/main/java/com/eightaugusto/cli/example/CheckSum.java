package com.eightaugusto.cli.example;

import java.io.File;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.Callable;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(
    name = "checksum",
    mixinStandardHelpOptions = true,
    version = "1.0.0",
    description = "Prints the checksum (SHA-256 by default).")
public class CheckSum implements Callable<Integer> {

  private static final int SUCCESS_CODE = 0;
  private static final int ERROR_CODE = 1;

  @Parameters(index = "0", description = "The file whose checksum to calculate.")
  private File file;

  @Option(
      names = {"-a", "--algorithm"},
      description = "MD5, SHA-1, SHA-256, ...")
  private String algorithm = "SHA-256";

  @Override
  public Integer call() {
    try {
      final byte[] digest =
          MessageDigest.getInstance(algorithm).digest(Files.readAllBytes(file.toPath()));
      System.out.printf("%0" + (digest.length * 2) + "x%n", new BigInteger(1, digest));
      return SUCCESS_CODE;
    } catch (NoSuchAlgorithmException | IOException ex) {
      System.out.printf("Error when trying to generate checksum: %s%n", ex);
      return ERROR_CODE;
    }
  }

  public static void main(String[] args) {
    System.exit(new CommandLine(new CheckSum()).execute(args));
  }
}
