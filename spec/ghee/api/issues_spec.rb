require 'spec_helper'

describe Ghee::API::Issues do 
  subject { Ghee.new(ACCESS_TOKEN) }

  def should_be_an_issue(issue)
    issue["user"]["login"].should_not be_nil
    issue["comments"].should_not be_nil
  end

  describe "#repos(login,name)#issues" do
    it "should return repos issues" do
      VCR.use_cassette("repos(rauhryan,skipping_stones_repo).issues") do
        issues = subject.repos("rauhryan","skipping_stones_repo").issues
        issues.size.should > 0
        should_be_an_issue(issues.first)
      end
    end
    describe "#repos(login,name)#issues#closed" do
      it "should return repos closed issues" do
        VCR.use_cassette("repos(rauhryan,skipping_stones_repo).issues.closed") do
          issues = subject.repos("rauhryan","skipping_stones_repo").issues.closed
          issues.size.should > 0
          should_be_an_issue(issues.first)
          issues.each do |i|
            i["state"].should == "closed"
          end
        end
      end
      it "should return repos closed issues with block" do
        VCR.use_cassette("repos(rauhryan,skipping_stones_repo).issues.closed&block") do
          issues = subject.repos("rauhryan","skipping_stones_repo").issues.closed do |req|
            req.params["state"] = "closed"
          end
          issues.size.should > 0
          should_be_an_issue(issues.first)
          issues.each do |i|
            i["state"].should == "closed"
          end
        end
      end
    end
    describe "#repos(login,name)#issues(1)" do
      it "should return an issue by id" do 
        VCR.use_cassette("repos(rauhryan,skipping_stones_repo).issues(1)") do
          issue = subject.repos("rauhryan","skipping_stones_repo").issues(1)
          should_be_an_issue(issue)
        end
      end

      # Testing issue proxy
      context "with issue number" do
        before(:all) do
          VCR.use_cassette "issues.test" do
            @repo = subject.repos("rauhryan","skipping_stones_repo")
            @test_issue = @repo.issues.create({
              :title => "Test issue"
            })
          end
        end
        let(:test_issue) { @test_issue }
        let(:test_repo) { @repo }

        describe "#patch" do 
          it "should patch the issue" do
            VCR.use_cassette "issues(id).patch" do
              issue = test_repo.issues(test_issue["number"]).patch({
                :body => "awesome description"
              })
              should_be_an_issue(issue)
              issue["body"].should == "awesome description"
            end
          end
        end

        describe "#close" do
          it "should close the issue" do 
            VCR.use_cassette "issues(id).close" do
              closed = test_repo.issues(test_issue["number"]).close
              closed.should be_true
            end
          end
        end


      end

    end
  end
end
