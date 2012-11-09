require 'spec_helper'

describe ApplicationHelper do
  describe "#close_standup" do
    it "picks a closing" do
      Date.stub_chain(:today, :wday).and_return(4)
      helper.should_receive(:rand).and_return(0)
      helper.standup_closing.should == "STRETCH!"
    end

    it "should remind us when its Floor Friday" do
      Date.stub_chain(:today, :wday).and_return(5)
      helper.standup_closing.should == "STRETCH! It's Floor Friday!"
    end
  end

  describe "#pending_post_count" do
    let(:standup) { create(:standup) }
    let(:other_standup) { create(:standup) }

    before { create(:post, standup: standup) }

    it "can count" do
      helper.pending_post_count(standup).should == 1
    end

    it "doesn't count unassociated standups" do
      helper.pending_post_count(other_standup).should == 0
    end
  end

  describe "#show_or_edit_post_path" do
    it "links to edit if not archived" do
      post = create(:post)
      helper.show_or_edit_post_path(post).should == edit_post_path(post)
    end

    it "links to show if archived" do
      post = create(:post, archived: true)
      helper.show_or_edit_post_path(post).should == post_path(post)
    end
  end

  describe "#format_title" do
    subject { helper.format_title(item) }

    context "the item is an event" do
      let(:item) { double(:item, kind: "Event", title: "Not Interesting", date: Date.tomorrow) }
      it { should == "#{item.date.strftime("%A(%m/%d)")}: #{item.title}" }
    end

    context "the item is not an event" do
      let(:item) { double(:item, kind: "Interesting", title: "Not Interesting") }
      it { should == item.title }
    end
  end

  describe "#date_label" do
    describe "when there is not a date" do
      let(:item) { create(:item, kind: "Help") }

      it "returns nothing" do
        label = helper.date_label(item)
        label.should be_blank
      end
    end

    describe "when there is a date" do
      describe "when passed an Event" do
        it "displays day of week" do
          event = create(:item, kind: "Event", date: Date.new(2012, 11, 05))
          label = helper.date_label(event)
          label.should == "Monday: "
        end
      end

      describe "when passed an Item that is not an Event" do
        let(:item) { create(:item, kind: "Help") }

        describe "when the date is <= today" do
          before do
            item.date = Date.yesterday
          end

          it "returns nothing" do
            label = helper.date_label(item)
            label.should be_blank
          end
        end

        describe "when the date is in the future" do
          before do
            Date.stub(today: Date.new(2012, 11, 05))
            item.date = Date.new(2012, 11, 07)
          end

          it "returns the day of the week" do
            label = helper.date_label(item)
            label.should == "Wednesday: "
          end
        end

        describe "when the date is more than a week away" do
          before do
            Date.stub(today: Date.new(2012, 11, 04))
            item.date = Date.new(2012, 11, 22)
          end

          it "displays the date rather than the day name" do
            label = helper.date_label(item)
            label.should == "11/22: "
          end
        end
      end
    end
  end
end
