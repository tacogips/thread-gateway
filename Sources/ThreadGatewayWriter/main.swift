import ThreadGateway
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

@main
struct ThreadGatewayWriterMain {
  static func main() async {
    let code = await ThreadGatewayCLI.runWriter(arguments: Array(CommandLine.arguments.dropFirst()))
    if code != 0 { exit(code) }
  }
}
