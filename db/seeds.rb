CATEGORIES = %w(잡화 의류 뷰티 전자제품 레져용품 생활용품 요리 자동차 기타)

def generate_user num
  names = ["김영희", "이철수", "박영수", "정동구", "최주공"]
  num.times do |index|
    user = User.create!(
      email: "#{ENV["TEST_EMAIL_FRONT"]}#{index+1}#{ENV["TEST_EMAIL_BACK"]}",
      password: "#{ENV["TEST_PASSWORD"]}",
      nickname: "tester#{index+1}",
      image: File.open("#{Rails.root}/public/image/default.png"),
      gender: :no_select,
      user_type: :normal,
      location_id: Location.all[index].position,
      location_range: :location_alone,
      body: "tester#{index+1} account.",
      name: names.sample,
      birthday: Faker::Date.between(from: '1990-01-01', to: '1999-12-31').strftime("%Y%m%d"),
      number: Faker::Base.numerify('010########')
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
      title: "테스트용",
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
  CSV.foreach("public/GroupEmail.csv", headers: true) do |row|
    begin
      group = Group.create!(row.to_hash)

      p "Group '#{group.title}' created"
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
generate_groups unless Group.exists?
