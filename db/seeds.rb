# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

CATEGORIES = %w(패션 뷰티 생활용품 가전 스포츠 자동차 도서)

def generate_user num
  num.times do |index|
    user = User.create!(
      email: "tester#{index+1}@test.com",
      password: "test123",
      nickname: "tester#{index+1}",
      image: File.open("#{Rails.root}/public/image/default.png")
    )
    p "User 'tester#{index+1}' created."
  end
end

def generate_categories
  CATEGORIES.each_with_index do |title, index|
    Category.create!(
      title: title,
      position: index
    )
    p "Category '#{title}' created."
  end
end

def generate_post
  user = User.first
  post = user.posts.create!(
    title: "맥북 프로 13인치 대여합니다!",
    body: "맥북 프로 13인치 2020년형 싸게 대여합니다. 관심있으신 분들 연락주세요.",
    price: "10000",
    image: File.open("#{Rails.root}/public/image/mac_1.jpeg")    
  )
  4.times do |index| 
    post.images.create!(image: File.open("#{Rails.root}/public/image/mac_#{index+1}.jpeg"))
  end

  p "Post '#{post.title}' created."
end

# seed func
generate_user 5
generate_categories
generate_post