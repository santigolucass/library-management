class AuthUserPresenter
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      email: @user.email,
      role: @user.role
    }
  end
end
