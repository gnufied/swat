require File.join(File.dirname(__FILE__) + "/../tests/test_helper")
require "todo_data"
context "For tick data in general" do
  setup do
    @todo_data = TodoData.new("/home/gnufied/snippets/todo.org")
  end
  specify "should have 3 categories" do
    @todo_data.todo_container.keys.length.should.be(3)
    @todo_data.todo_container["Backgroundrb Tasks"].length.should == 11
    @todo_data.todo_container["Backgroundrb Tasks"][0].text.should == "log the message if worker quits"
    @todo_data.todo_container["Backgroundrb Tasks"][0].flag.should == false
    @todo_data.todo_container["Backgroundrb Tasks"][0].priority.should == 2
    @todo_data.todo_container["Backgroundrb Tasks"][9].text.should == "Think about saving results from workers, which aren't around anymore."
    @todo_data.todo_container["Backgroundrb Tasks"][9].flag.should == true
    @todo_data.todo_container["Backgroundrb Tasks"][9].priority.should == 2
  end

  specify "should yield tasks which are yet to be done" do
    category_yield_count = 0
    @todo_data.open_tasks_with_index do |category,todo_array,index|
      category_yield_count += 1
      ["Backgroundrb Tasks","Packet Tasks","Swat Tasks"].should.include(category)
      priority_array = todo_array.map { |x| x.priority}
      priority_array.should == [2, 2] if category == "Packet Tasks"
    end
    category_yield_count.should == 3
  end
end

