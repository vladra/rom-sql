require 'spec_helper'

describe 'Defining many-to-one association' do
  include_context 'users and tasks'

  before do
    conn[:tasks].insert id: 2, user_id: 1, title: 'Go to sleep'
  end

  it 'extends relation with association methods' do
    setup.relation(:tasks) do

      many_to_many :tags,
        join_table: :task_tags,
        left_key: :task_id,
        right_key: :tag_id

      def with_tags
        association_left_join(:tags).select(:tasks__id, :tasks__title, :tags__name)
      end

      def by_tag(name)
        with_tags.where(tags__name: name)
      end
    end

    setup.relation(:tags)

    tasks = rom.relations.tasks

    expect(tasks.with_tags.to_a).to eql([
      { id: 1, title: 'Finish ROM', name: 'important' },
      { id: 2, title: 'Go to sleep', name: nil }
    ])

    expect(tasks.by_tag("important").to_a).to eql([
      { id: 1, title: 'Finish ROM', name: 'important' }
    ])

    expect(tasks.by_tag("not-here").to_a).to be_empty
  end
end