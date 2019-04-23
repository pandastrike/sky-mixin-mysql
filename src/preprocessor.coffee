# Panda Sky Mixin: MySQL
# This mixin allocates a serverless MySQL database within your deployment.
import {cat, isObject} from "panda-parchment"
import {keyLookup, secretLookup} from "./utils"

process = (SDK, config) ->

  # Start by extracting out the MySQL Mixin configuration:
  {env, tags=[]} = config
  c = config.aws.environments[env].mixins.mysql
  c = if isObject c then c else {}
  c.tags = cat (c.tags || []), tags

  # This mixin only works with a VPC
  unless config.aws.vpc
    throw new Error "The MySQL mixin can only be used in environments featuring a VPC."

  # Expand the "cluster" configuration with defaults.
  {cluster, tags} = c
  unless cluster.name
    cluster.name = config.environmentVariables.fullName

  await secretLookup SDK, cluster.password
  cluster.masterUsername =
    "{{resolve:secretsmanager:#{cluster.password}:SecretString:username}}"
  cluster.masterUserPassword =
    "{{resolve:secretsmanager:#{cluster.password}:SecretString:password}}"

  unless cluster.backupTTL
    cluster.backupTTL = 1

  unless cluster.backtrackTTL
    cluster.backtrackTTL = 1

  unless cluster.backupWindow
    cluster.backupWindow = "06:00-07:00" # 11pm - 12am PST

  unless cluster.maintenanceWindow
    cluster.maintenanceWindow = "Wed:07:00-Wed:08:00"  # 12am - 1am PST

  if cluster.kmsKey
    cluster.kmsKey = await keyLookup SDK, cluster.kmsKey

  cluster.capacity ?= {}
  unless cluster.capacity.min
    cluster.capacity.min = 2
  unless cluster.capacity.max
    cluster.capacity.max = 64

  {tags, cluster}

export default process
