defprotocol Repo.Validator do
  def stop(validator)
  def create(validator, entry)
end
