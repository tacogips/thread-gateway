import ThreadGateway
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

@main
struct ThreadGatewayReaderMain {
  static func main() async {
    let code = await ThreadGatewayCLI.runReader(arguments: Array(CommandLine.arguments.dropFirst()))
    if code != 0 { exit(code) }
  }
}
