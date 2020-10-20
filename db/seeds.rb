CATEGORIES = %w(잡화 의류 뷰티 전자제품 레져용품 생활용품 요리 자동차)

def generate_user num
  num.times do |index|
    user = User.create!(
      email: "tester#{index+1}@test.com",
      password: "test123",
      nickname: "tester#{index+1}",
      image: File.open("#{Rails.root}/public/image/default.png"),
      gender: :no_select,
      user_type: :normal,
      location_id: Location.all[index].id,
      location_range: :location_alone,
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

def generate_post num
  
  num.times do |index|
    user = User.all[index]
    
    post = user.posts.create!(
      title: "맥북 프로 13인치 대여합니다!",
      body: "맥북 프로 13인치 2020년형 싸게 대여합니다. 관심있으신 분들 연락주세요.",
      price: "10000",
      image: File.open("#{Rails.root}/public/image/mac_1.jpeg"),
      post_type: :provide,
      status: :able,
      category_id: Category.find_by(title: "전자제품").id,
      location_id: user.location.id
    )
    4.times do |jndex| 
      post.images.create!(image: File.open("#{Rails.root}/public/image/mac_#{jndex+1}.jpeg"))
    end

    p "Post #{index+1} '#{post.title}' created."
  end

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
generate_admin unless AdminUser.where(email: "#{ENV["ACTIVEADMIN_EMAIL"]}").exists?
generate_categories unless Category.exists?
generate_locations unless Location.exists?
generate_user 5 unless User.exists?
generate_post 5 unless Post.exists?