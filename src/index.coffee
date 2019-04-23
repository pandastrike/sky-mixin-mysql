import {resolve} from "path"
import MIXIN from "panda-sky-mixin"
import {read} from "panda-quill"
import {yaml} from "panda-serialize"

import getPolicyStatements from "./policy"
#import getEnvironmentVariables from "./environment-variables"
import preprocess from "./preprocessor"
#import cli from "./cli"

get = (name) -> read resolve __dirname, "..", "..", "..", "files", name

mixin = do ->
  schema = yaml await get "schema.yaml"
  schema.definitions = yaml await get "definitions.yaml"
  template = await get "template.yaml"

  new MIXIN {
    name: "mysql"
    schema
    template
    preprocess
    #cli
    getPolicyStatements
    #getEnvironmentVariables
  }

export default mixin
