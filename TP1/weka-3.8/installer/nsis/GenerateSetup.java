/*
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * GenerateSetup.java
 * Copyright (C) 2006 University of Waikato, Hamilton, New Zealand
 *
 */

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Vector;

/**
 * Generates a setup file for <a href="http://nsis.sourceforget.net"
 * target="_blank">NSIS</a>.
 *
 * @author    FracPete (fracpete at waikato dot ac dot nz)
 * @version   $Revision$
 */
public class GenerateSetup {

  /** the templates directory */
  public final static String TEMPLATES = "templates";

  /** the images directory */
  public final static String IMAGES = "images";

  /** the batch file for JRE */
  public final static String JRE_BATCH = "RunJREInstaller.bat";

  /** the version */
  protected String mVersion = "";

  /** the input directory */
  protected String mInputDir = "";

  /** the output directory */
  protected String mOutputDir = "";

  /** the directory for Weka (in "Program Files") */
  protected String mDir = "";

  /** the prefix for links */
  protected String mLinkPrefix = "";

  /** the jre file */
  protected String mJRE = "";

  /** 64 bit install */
  protected String m64 = "";

  /**
   * initializes the setup generator
   */
  public GenerateSetup() {
    super();
  }
  
  /**
   * sets the version number
   *
   * @param value       the version number
   */
  public void setVersion(String value) {
    mVersion = value;
  }
  
  /**
   * sets the input directory
   *
   * @param value       the dir
   */
  public void setInputDir(String value) {
    mInputDir = value;
  }
  
  /**
   * sets the output directory
   *
   * @param value       the dir
   */
  public void setOutputDir(String value) {
    mOutputDir = value;
  }
  
  /**
   * sets the directory for Weka used in the setup
   *
   * @param value       the dir
   */
  public void setDir(String value) {
    mDir = value;
  }

  public void set64(String value) {
    m64 = value;
  }
  
  /**
   * sets the link prefix
   *
   * @param value       the prefix
   */
  public void setLinkPrefix(String value) {
    mLinkPrefix = value;
  }
  
  /**
   * sets the JRE filename
   *
   * @param value       the filename
   */
  public void setJRE(String value) {
    mJRE = value;
  }

  /**
   * writes the given vector to the specified file
   *
   * @param content     the content to write
   * @param filename    the file to write to
   * @return            if writing was successful
   */
  protected static boolean writeToFile(Vector content, String filename) {
    StringBuffer    contentStr;
    int             i;

    contentStr = new StringBuffer();
    for (i = 0; i < content.size(); i++)
      contentStr.append(content.get(i).toString() + "\n");

    return writeToFile(contentStr.toString(), filename);
  }

  /**
   * writes the given content to the specified file
   *
   * @param content     the content to write
   * @param filename    the file to write to
   * @return            if writing was successful
   */
  protected static boolean writeToFile(String content, String filename) {
    BufferedWriter  writer;
    boolean         result;
    File            file;

    result = true;

    try {
      // do we need to create dir?
      file = new File(filename);
      if (!file.getParentFile().exists())
        file.getParentFile().mkdirs();
      
      // content
      writer = new BufferedWriter(new FileWriter(file));
      writer.write(content);
      writer.flush();
      writer.close();
    }
    catch (Exception e) {
      e.printStackTrace();
      result = false;
    }

    return result;
  }

  /**
   * indents the given string by count spaces and returns it
   *
   * @param line      the string to indent
   * @param count     the number of spaces
   * @return          the indented string
   */
  protected String indent(String line, int count) {
    String      result;
    int         i;

    result = line;
    for (i = 0; i < count; i++)
      result = " " + result;

    return result;
  }

  /**
   * replaces code blocks, surrounded by "# Start: identifier" and 
   * "# End: identifier" with the given content and returns the new
   * list
   *
   * @param lines       the current text
   * @param identifier  the identifier to look for
   * @param content     the new content between the start/end comment
   * @return            the new text
   */
  protected Vector replaceBlock(Vector lines, String identifier, String content) {
    Vector      result;
    String      start;
    String      end;
    int         i;
    boolean     skip;

    result = new Vector();
    start  = "# Start: " + identifier;
    end    = "# End: " + identifier;
    skip   = false;

    for (i = 0; i < lines.size(); i++) {
      if (lines.get(i).toString().indexOf(start) > -1) {
        result.add(lines.get(i).toString());
        if (content.length() == 0)
          result.add(
              indent("# removed", lines.get(i).toString().indexOf(start)));
        else
          result.add(content);
        skip = true;
        continue;
      }
      else if (lines.get(i).toString().indexOf(end) > -1) {
        result.add(lines.get(i).toString());
        skip = false;
        continue;
      }
      else {
        if (!skip)
          result.add(lines.get(i).toString());
      }
    }

    return result;
  }
  
  /**
   * loads the file and returns the lines in a Vector
   * 
   * @param filename  the file to load
   * @return          the content of the file
   */
  public Vector loadFile(String filename) {
    Vector            result;
    BufferedReader    reader;
    String            line;
    
    result = new Vector();
    
    try {
      reader = new BufferedReader(new FileReader(filename));
      while ((line = reader.readLine()) != null)
        result.add(line);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    
    return result;
  }

  /**
   * generates the setup file
   *
   * @return        true if generation was successful
   */
  protected boolean generateSetupFile() {
    Vector            setup;
    String            block;
    String            versionHyphen;

    versionHyphen = mVersion.replaceAll("\\.", "-");

    // load file
    boolean use64bit = false;
    if (m64.length() > 0) {
      if (m64.equalsIgnoreCase("true")) {
        use64bit = true;
      }
    }
    String setupFile = (use64bit) ? "setup64.nsi" : "setup.nsi";
    setup = loadFile(TEMPLATES + "/" + setupFile);

    // find the name of the unpacked jre
    File jreDir = new File(mInputDir + File.separator + "jre");
    File[] contents = jreDir.listFiles();
    if (contents == null || contents.length != 1) {
	throw new RuntimeException("There should only be one subdirectory in the jre directory!");
    }
    String jreSubDir = contents[0].getName();

    // Weka
    block = "";
    block += "!define WEKA_WEKA \"Weka\"\n";
    block += "!define WEKA_VERSION \"" + mVersion + "\"\n";
    block += "!define WEKA_VERSION_HYPHEN \"" + versionHyphen + "\"\n";
    block += "!define WEKA_FILES \"" + new File(mInputDir).getAbsolutePath() + "\"\n";
    block += "!define WEKA_TEMPLATES \"" + new File(TEMPLATES).getAbsolutePath() + "\"\n";
    block += "!define WEKA_LINK_PREFIX \"" + mLinkPrefix + "\"\n";
    block += "!define WEKA_DIR \"" + mDir + "\"\n";
    block += "!define WEKA_URL \"http://www.cs.waikato.ac.nz/~ml/weka/\"\n";
    block += "!define WEKA_MLGROUP \"Machine Learning Group, University of Waikato, Hamilton, NZ\"\n";
    block += "!define WEKA_HEADERIMAGE \"" + new File(IMAGES + "/weka_new.bmp").getAbsolutePath() + "\"\n";
    //    block += "!define WEKA_JRE \"" + new File(mJRE).getAbsolutePath() + "\"\n";
    block += "!define WEKA_JRE \"jre\\" + jreSubDir + "\"\n";
    block += "!define WEKA_JRE_TEMP \"jre_setup.exe\"\n";
    block += "!define WEKA_JRE_INSTALL \"RunJREInstaller.bat\"\n";
    if (mJRE.length() != 0)
      block += "!define WEKA_JRE_SUFFIX \"jre\"";
    else
      block += "!define WEKA_JRE_SUFFIX \"\"";

    setup = replaceBlock(setup, "Weka", block);

    // no JRE?
    if (mJRE.length() == 0)
      setup = replaceBlock(setup, "JRE", "");

    // write file
    if (mJRE.length() != 0)
      return writeToFile(
          setup, 
          mOutputDir + "/weka-" + versionHyphen + "jre" + (use64bit ? "-x64" : "") + ".nsi");
    else
      return writeToFile(
          setup, 
          mOutputDir + "/weka-" + versionHyphen + (use64bit ? "-x64" : "") + ".nsi");
  }

  /**
   * generates the output
   *
   * @return      true if generation was successful
   */
  public boolean execute() {
    boolean     result;

    result = true;

    if (result)
      result = generateSetupFile();

    return result;
  }

  /**
   * returns the value for the given option
   *
   * @param option  the option to retrieve the value for (excluding "-")
   * @param list    the commandline options
   * @return        the value of the option, can be empty
   */
  protected static String getOption(String option, String[] list) {
    String    result;
    int       i;

    result = "";

    for (i = 0; i < list.length - 1; i++) {
      if (list[i].equals("-" + option)) {
        result = list[i + 1];
        break;
      }
    }

    return result;
  }

  /**
   * runs the generator with the necessary parameters.
   *
   * @param args        the commandline parameters
   * @throws Exception  if something goes wrong
   */
  public static void main(String[] args) throws Exception {
    GenerateSetup generator;

    generator = new GenerateSetup();
    generator.setVersion(getOption("version", args));
    generator.setInputDir(getOption("input-dir", args));
    generator.setOutputDir(getOption("output-dir", args));
    generator.setDir(getOption("dir", args));
    generator.setLinkPrefix(getOption("link-prefix", args));
    generator.setJRE(getOption("jre", args));
    generator.set64(getOption("x64", args));
    System.out.println("Result = " + generator.execute());
  }
}
