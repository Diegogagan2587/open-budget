class AddPolymorphicContextToTasksDocsMeetings < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :taskable, polymorphic: true, index: true
    add_reference :docs, :documentable, polymorphic: true, index: true
    add_reference :meetings, :meetingable, polymorphic: true, index: true
  end
end
