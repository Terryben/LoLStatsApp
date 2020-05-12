class Dog  
	def initialize(breed, name)  
		      # Instance variables  
		  @breed = breed  
		  @name = name  
	end  
	def bark  
       		puts 'Ruff! Ruff!'  
  	end  
   
  	def display  
      		puts "I am of #{@breed} breed and my name is #{@name}"  
  	end  
end

d = Dog.new('Labrador', 'Benzy')

puts "The id of d is #{d.object_id}."
