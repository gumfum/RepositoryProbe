package net.exkazuu.probe

import java.io.File
import java.util.List
import net.exkazuu.probe.git.GitManager
import net.exkazuu.probe.github.GithubRepositoryInfo
import net.exkazuu.probe.maven.MavenManager
import net.exkazuu.probe.sonar.SonarManager
import org.openqa.selenium.chrome.ChromeDriver

/**
 * A class for measuring metrics by execution SonarQube.
 * 
 * @author Ryohei Takasawa
 */
class SonarExecutor {
	protected val File csvFile
	protected val List<GithubRepositoryInfo> infos
	val File mvnDir
	val int skipCount

	new(File csvFile, int skipCount, File mvnDir) {
		this.csvFile = csvFile
		this.skipCount = skipCount
		this.infos = GithubRepositoryInfo.readList(csvFile)
		this.mvnDir = mvnDir
		mvnDir.mkdirs()
	}

	def run() {
		val driver = new ChromeDriver()
		infos.drop(skipCount).forEach [ info, i |
			try {
				if (info.killedMutantCountWithXMutator >= 0) {
					System.out.println((i + skipCount + 1) + ": " + info.url)
					val userDir = new File(mvnDir.path, info.userName)
					val projectDir = new File(userDir.path, info.projectName)
					userDir.mkdirs()
					System.out.print("Clone repository ... ")
					new GitManager(projectDir).cloneAndCheckout(info.url, info.mainBranch, "origin/" + info.mainBranch)
					System.out.println("done")
					System.out.print("Execute sonar ... ")
					new SonarManager(new MavenManager(projectDir), driver).execute(info)
					System.out.println("done")
					GithubRepositoryInfo.write(csvFile, infos)
				}
			} catch (Exception e) {
			}
		]
		driver.close
	}

	def static void main(String[] args) {
		if (args.length <= 1) {
			System.out.println("Please specify two argument indicating a csv file and a skip count.")
			System.exit(-1)
		}

		val csvFile = new File(args.get(0))
		val skipCount = Integer.parseInt(args.get(1))
		val executor = new SonarExecutor(csvFile, skipCount, new File("repos"))
		executor.run()
	}
}
