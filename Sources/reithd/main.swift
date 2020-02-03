import Commander
import ReithDCore

let app = Group {
  $0.command("start") {
    startDaemon()
  }

  $0.command("shell") {
    print(ShellConfigurer.shellScript)
  }
}

app.run()
