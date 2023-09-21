require 'socket'

def scan(host, port)
  begin
    sock = TCPSocket.new(host, port)
    sock.close
    puts "[+] Port #{port} is open on #{host}."
  rescue Errno::ECONNREFUSED
    puts "[-] Port #{port} is closed on #{host}."
  rescue Errno::EHOSTUNREACH
    puts "[-] #{port} is unreachable on #{host}."
  rescue SocketError => e
    puts "[-] Error occurred while connecting to #{host}: #{e.message}"
  end
end

host = ARGV[0]
ports = ARGV[1].split(",")
threads = []

ports.each do |port|
  threads << Thread.new do
    result = scan(host, port)
  end
end

threads.each(&:join)
