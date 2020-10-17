# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CATEGORIES = %w(패션 뷰티 생활용품 가전 스포츠 자동차 도서)
# LOCATIONS = %w(파장동 이목동 천천동 율전동 정자동 영화동 송죽동 조원동 연무동 상광교동 하광교동 세류동 장지동 오목천동 평동 고색동 평리동 호매실동 금곡동 구운동 서둔동 탑동 권선동 곡반전동 대황교동 입북동 당수동 팔달로1가 팔달로2가 팔달로3가 남창동 영동 구천동 중동 매향동 남수동 북수동 장안동 신풍동 매교동 교동 매산로1가 매산로2가 매산로3가 고등동 화서동 지동 우만동 인계동 매탄동 원천동 이의동 하동 영통동 신동 망포동)

def generate_user num
  num.times do |index|
    user = User.create!(
      email: "tester#{index+1}@test.com",
      password: "test123",
      nickname: "tester#{index+1}",
      image: File.open("#{Rails.root}/public/image/default.png"),
      gender: :no_select,
      user_type: :normal,
      body: "tester#{index+1} account."
    )
    p "User 'tester#{index+1}' created."
  end
end

def generate_admin
  AdminUser.create!(email: "#{ENV["ACTIVEADMIN_EMAIL"]}", password: "#{ENV["ACTIVEADMIN_PASSWD"]}", password_confirmation: "#{ENV["ACTIVEADMIN_PASSWD"]}")
  p "Admin created."
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
  user = User.last
  post = user.posts.create!(
    title: "맥북 프로 13인치 대여합니다!",
    body: "맥북 프로 13인치 2020년형 싸게 대여합니다. 관심있으신 분들 연락주세요.",
    price: "10000",
    image: File.open("#{Rails.root}/public/image/mac_1.jpeg"),
    post_type: :provide,
    status: :able
  )
  4.times do |index| 
    post.images.create!(image: File.open("#{Rails.root}/public/image/mac_#{index+1}.jpeg"))
  end

  p "Post '#{post.title}' created."
end

def generate_locations
  CSV.foreach("public/SuwonLocation.csv", headers: true) do |row|
    begin
      location = Location.create!(row.to_hash)
      p "Location '#{location.title}' created."
    rescue => e
      p e.message
    end
  end
end

# seed functions
generate_user 5 unless User.exists?
generate_admin unless AdminUser.where(email: "#{ENV["ACTIVEADMIN_EMAIL"]}").exists?
generate_categories unless Category.exists?
generate_locations unless Location.exists?
generate_post unless Post.exists?