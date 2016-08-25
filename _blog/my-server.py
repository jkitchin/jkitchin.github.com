from epc.server import EPCServer

server = EPCServer(('localhost', 0))

@server.register_function
def echo(*a):
    return 'from python ' + str(a)

server.print_port()
server.serve_forever()
