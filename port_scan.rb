require 'socket'

def port_scan(host, port, timeout_seconds = 1)
  socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  sockaddr = Socket.sockaddr_in(port, host)

  begin
    socket.connect_nonblock(sockaddr)
    puts "#{port} Open."
  rescue IO::WaitWritable
    IO.select(nil, [socket], nil, timeout_seconds)
    retry
  rescue Errno::EISCONN
    puts "#{port} Open."
  rescue Errno::ECONNREFUSED
    puts "#{port} Closed (Error: Connection refused)."
  rescue Errno::ETIMEDOUT
    puts "#{port} Closed (Error: Connection timed out)."
  rescue Errno::EHOSTUNREACH
    puts "#{port} Closed (Error: Host unreachable)."
  rescue Errno::ENETUNREACH
    puts "#{port} Closed (Error: Network unreachable)."
  rescue Errno::EINVAL
    puts "#{port} Closed (Error: Invalid argument)."
  rescue Exception => e
    puts "#{port} closed: #{e.message}"
  ensure
    socket&.close
  end
end

def port_scan_with_threads(host, port_list, timeout_seconds = 1)
  threads = []

  port_list.each do |port|
    threads << Thread.new { port_scan(host, port, timeout_seconds) }
  end

  threads.each(&:join)
end

host = 'target.com'
port_list = [21, 22, 23, 25, 53, 80, 139, 443, 445, 3306, 8080, 3389, 5900, 8081]

port_scan_with_threads(host, port_list, 1)
