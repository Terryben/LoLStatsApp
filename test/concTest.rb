 def get_running_thread_count #borrowed from used Kashyap on Stack Overflow
	 Thread.list.select {|thread| thread.status == "run"}.count
 end   
x = Thread.new {
	sleep 1
	puts "Hello"
	sleep 1
	puts "Father"
}
y = Thread.new {
	puts "My"
	sleep 1
	puts "good"
	sleep 1
}
puts "Thread count is #{get_running_thread_count}"
x.join
y.join



