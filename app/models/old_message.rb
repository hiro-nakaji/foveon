class OldMessage < ActiveRecord::Base
  establish_connection :foveon
  self.table_name = 'tb_bbs'
  acts_as_tree order: 'lastupdate'

  # Return Hash for a 'Message'
  #
  # @return Hash
  def message_hash
    homepage = self.url
    homepage = "http://" + homepage unless homepage.blank? || homepage.start_with?('http')
    {
      old_id:         self.id,
      created_at:     self.lastupdate,
      updated_at:     self.lastmodified,
      author:         self.author,
      mail:           self.mailaddr,
      homepage:       homepage,
      title:          self.title,
      content:        self.data,
      remote_addr:    self.address,
      user_agent:     self.browser,
      password:       self.password.present? ? self.password : SecureRandom.hex,
      message_type:  'text'
    }
  end
end