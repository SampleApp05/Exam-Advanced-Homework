import { writeFile, mkdir } from "fs/promises";
import path from "path";

/**
 * Writes arbitrary JSON data to a file in the deployment directory.
 * @param filename Name of the file (without path)
 * @param data Any data object to write
 * @param subdir Optional subdirectory (e.g., network name)
 */
export async function writeToFile(
  filename: string,
  data: any,
  subdir: string = ""
) {
  const baseDir = path.resolve(__dirname, "../output", subdir);
  const filePath = path.join(
    baseDir,
    filename.endsWith(".json") ? filename : `${filename}.json`
  );

  await mkdir(baseDir, { recursive: true });
  await writeFile(filePath, JSON.stringify(data, null, 2));

  console.log(`✅ Data written to ${filePath}`);
}
