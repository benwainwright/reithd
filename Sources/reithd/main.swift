import Commander
import ReithDCore

let app = Group {
  $0.command("start") {
    startDaemon()
  }

  $0.command("initShell") {
    print(ShellConfigurer.shellScript)
  }
}

app.run()
