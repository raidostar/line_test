group = Group.find_by(id: 1)
if !group.present?
  @group = Group.new({group: 'FullouT', password: 'fullout2020', admit: true})
  @group.save
end

@user = User.find_by(id: 1)
if @user.present?
  @user.update(status: 'admin')
end