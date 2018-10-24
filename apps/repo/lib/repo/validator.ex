defprotocol Repo.Validator do
  def stop(validator)
  def create(validator, entry)
  def revalidate(validator, entries)
end
