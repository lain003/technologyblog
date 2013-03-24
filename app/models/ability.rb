class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, Blog
    can :read, User
    if user.respond_to?(:admin?) && user.admin?
      can :manage, Blog
      can :manage, User
    end
  end
end
