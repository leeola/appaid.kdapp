# 
# # App Views
#
{Views}     = App
{notify}    = App.Utilities




# # MainView
#
class Views.MainView extends KDView
  constructor: (options={}, data)->
    options.cssClass ?= "appaid-mainview"
    super options, data
    
    barView = new KDView()

    previewView = new KDView()

    @addSubView barView
    @addSubView @previewView


