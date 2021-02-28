require 'rails_helper'

RSpec.describe Post, type: :model do
  #게시물 생성 관련 테스트
  context 'post creation test' do
    xit "need title" do
      post = Post.new(title: "", body: "test", price: 15000, post_type: 0, user_id: User.first.id, location_id: Location.first.id).save
      expect(post).to eq(false)
    end
    
    xit "need body" do
      post = Post.new(title: "test", body: "", price: 15000, post_type: 0, user_id: User.first.id, location_id: Location.first.id).save
      expect(post).to eq(false)
    end

    xit "need price" do
      post = Post.new(title: "test", body: "test", price: nil, post_type: 0, user_id: User.first.id, location_id: Location.first.id).save
      expect(post).to eq(false)
    end

    xit "need post_type" do
      post = Post.new(title: "test", body: "test", price: 15000, post_type: nil, user_id: User.first.id, location_id: Location.first.id).save
      expect(post).to eq(false)
    end

    xit "need user_id" do
      post = Post.new(title: "test", body: "test", price: 15000, post_type: nil, user_id: nil, location_id: Location.first.id).save
      expect(post).to eq(false)
    end

    xit "need location_id" do
      post = Post.new(title: "test", body: "test", price: 15000, post_type: nil, user_id: User.first.id, location_id: nil).save
      expect(post).to eq(false)
    end

    xit "success_case" do
      post = Post.new(title: "test", body: "test", price: 15000, product: "test", post_type: 0, user_id: User.first.id, category_id: Category.first.id, location_id: Location.first.id).save
      expect(post).to eq(true)
    end

  end
end
