CATEGORIES = %w(잡화 의류 뷰티 전자제품 레져용품 생활용품 요리 자동차 기타)

def generate_user num
  names = ["김영희", "이철수", "박영수", "정동구", "최주공"]
  num.times do |index|
    user = User.create!(
      email: "tester#{index+1}@test.com",
      password: "test123",
      nickname: "tester#{index+1}",
      image: nil, # File.open("#{Rails.root}/public/image/default.png"),
      gender: :no_select,
      user_type: :normal,
      location_id: Location.all[index].position,
      location_range: :location_alone,
      body: "tester#{index+1} account.",
      name: names.sample,
      birthday: Faker::Date.between(from: '1990-01-01', to: '1999-12-31').strftime("%Y%m%d"),
      number: Faker::Base.numerify('010########')
    )
    if user.presisted?
      p "User 'tester#{index+1}' created."
    else
      p user.errors.messages
    end
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
      title: "테스트용 게시글",
      body: "맥북 프로 13인치 2020년형 싸게 대여합니다. 관심있으신 분들 연락주세요.",
      product: "맥북 프로 13인치",
      price: "10000",
      image: File.open("#{Rails.root}/public/image/mac_1.jpeg"),
      post_type: :provide,
      status: :able,
      category_id: Category.find_by(title: "전자제품").id,
      location_id: user.location.position,
      rent_count: index
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
      one_location = row.to_hash
      one_location["location_near"] = one_location["location_near"].split(",").map{ |s| s.to_i }
      one_location["location_normal"] = one_location["location_normal"].split(",").map{ |s| s.to_i }
      one_location["location_far"] = one_location["location_far"].split(",").map{ |s| s.to_i }
      
      location = Location.create!(one_location)
      
      p "Location '#{location.title}' created."
    rescue => e
      p e.message
    end
  end
end

def generate_groups
  CSV.foreach("public/SchoolEmail.csv", headers: true) do |row|
    begin
      group = Group::School.create!(row.to_hash)
      p "School '#{group.title}' created"
    rescue => e
      p e.message
    end
  end

  CSV.foreach("public/FirmEmail.csv", headers: true) do |row|
    begin
      group = Group::Firm.create!(row.to_hash)
      p "Firm '#{group.title}' created"
    rescue => e
      p e.message
    end
  end
end

# seed functions
p "current environment: #{Rails.env}"
generate_admin unless AdminUser.where(email: "#{ENV["ACTIVEADMIN_EMAIL"]}").exists? || Rails.env.test?
generate_categories unless Category.exists?
generate_locations unless Location.exists?
generate_user 5 unless User.exists? || Rails.env.production?
generate_post 5 unless Post.exists?
generate_groups unless Group.exists?
