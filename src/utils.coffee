import Sundog from "sundog"

keyLookup = (SDK, name) ->
  {AWS:{KMS}} = await Sundog SDK
  {get} = KMS()
  try
    {Arn} = await get "alias/#{name}"
    Arn
  catch e
    throw new Error "The KMS key \"#{name}\" is not found."

secretLookup = (SDK, name) ->
  {AWS:{ASM}} = await Sundog SDK
  {exists} = ASM()
  unless await exists name
    throw new Error "The AWS Secrets Manager reference \"#{name}\" is not found."

export {keyLookup, secretLookup}
