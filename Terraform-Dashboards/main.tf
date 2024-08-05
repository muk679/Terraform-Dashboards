resource "newrelic_one_dashboard" "exampledash" {
  name        = "Infra Dashboard Terraform"
  permissions = "public_read_only"
   
  page {
    name = "New Relic Terraform Infra Example"


    widget_billboard {
      title  = "CPU Usage"
      row    = 1
      column = 1
      width  = 6
      height = 3

      nrql_query {
        query = "FROM SystemSample SELECT average(cpuPercent) SINCE 1 minute ago"
      }
    }

    widget_table {
      title = "process count"
      column = 1
      height = 3
      row = 12
      width = 12
 
      nrql_query {
        query = "SELECT count(*) FROM ProcessSample WHERE entityName = 'CEQ-ICT-LAPTOP-287' FACET processDisplayName"
      }
    }

    widget_bar {
      title  = "Memory Usage by Host"
      row    = 1
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM SystemSample SELECT average(memoryUsedBytes/memoryTotalBytes*100) AS 'Memory Usage' FACET hostname SINCE 1 minute ago"
      }

      # Must be another dashboard GUID
      //linked_entity_guids = ["abc123"]
    }

    

    widget_bar {
      title  = "Disk I/O by Host"
      row    = 4
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM SystemSample SELECT average(diskReadBytesPerSecond + diskWriteBytesPerSecond) AS 'Disk I/O' FACET hostname SINCE 1 minute ago"
      }

      # Must be another dashboard GUID 
      filter_current_dashboard = true

      # color customization
      colors {
        color = "#722727"
        series_overrides {
          color = "#722322"
          series_name = "Node"
        }
        series_overrides {
          color = "#236f70"
          series_name = "Java"
        }
      }
    }

    widget_line {
      title  = "Network I/O"
      row    = 4
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM SystemSample SELECT average(receiveBytesPerSecond + transmitBytesPerSecond) AS 'Network I/O' TIMESERIES SINCE 1 hour ago"
      }

      legend_enabled = true
      ignore_time_range = false
      y_axis_left_zero = true
      y_axis_left_min = 0

      y_axis_right {
        y_axis_right_zero   = true
        y_axis_right_min    = 0
        y_axis_right_max    = 1000
        y_axis_right_series = ["A", "B"]
      }

      is_label_visible = true

      threshold {
        name     = "Network I/O Threshold"
        from     = 500 
        to       = 1000
        severity = "critical"
      }

      threshold {
        name     = "Network I/O Warning"
        from     = 300
        to       = 499
        severity = "warning"
      }

      units {
        unit = "bytes/sec"
        series_overrides {
          unit = "bytes/sec"
          series_name = "Network I/O"
        }
      }
    }

    widget_markdown {
      title  = "Dashboard Note"
      row    = 10
      column = 1
      width  = 12
      height = 3

      text = "### Helpful Links\n\n* [New Relic One](https://one.newrelic.com)\n* [Developer Portal](https://developer.newrelic.com)"
    }


    widget_line {
      title = "Overall CPU % Statistics"
      row = 7
      column = 1
      height = 3
      width = 4

      nrql_query {
        query = <<EOT
SELECT average(cpuSystemPercent), average(cpuUserPercent), average(cpuIdlePercent), average(cpuIOWaitPercent) FROM SystemSample  SINCE 1 hour ago TIMESERIES
EOT
      }
      facet_show_other_series = false
      legend_enabled = true
      ignore_time_range = false
      y_axis_left_zero = true
      y_axis_left_min = 0
 
      null_values {
        null_value = "default"

        series_overrides {
          null_value = "remove"
          series_name = "Avg Cpu User Percent"
        }

        series_overrides {
          null_value = "zero"
          series_name = "Avg Cpu Idle Percent"
        }

        series_overrides {
          null_value = "default"
          series_name = "Avg Cpu IO Wait Percent"
        }

        series_overrides {
          null_value = "preserve"
          series_name = "Avg Cpu System Percent"
        }
      }
    }
     widget_table {
            title  = "process for Process ID"
            row    = 1
            column = 1
            width  = 6
            height = 3

            nrql_query {
                account_id = 4510907
                query      = "FROM ProcessSample SELECT processId WHERE processId IN ({{processid}})"
            }

            legend_enabled = true
           // y_axis_left_zero = true
            y_axis_left_min = 0
        }
  }
  
  
  variable {
    default_values     = [" "]
    is_multi_selection = false
    item {
      title = "processid"
      value = "processid"
    }
    name = "processid"
    nrql_query {
      account_ids = [4510907]
      query       = "SELECT uniques(processId) from ProcessSample"
    }
    replacement_strategy = "default"
    title                = "processid"
    type                 = "nrql"
  }
}

/////////////////////////////////////// APM DASHBOARD /////////////////////////////////////////////////////

resource "newrelic_one_dashboard" "exampledash-apm" {
  name        = "APM Dashboard Terraform"
  permissions = "public_read_only"

  page {
    name = "New Relic Terraform APM Example"

    widget_billboard {
      title  = "Average Transaction Duration"
      row    = 1
      column = 1
      width  = 6
      height = 3

      nrql_query {
        query = "FROM Transaction SELECT average(duration) SINCE 1 minute ago"
      }
    }

    widget_bar {
      title  = "Error Rate by Application"
      row    = 1
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM Transaction SELECT percentage(count(*), WHERE error IS true) AS 'Error Rate' FACET appName SINCE 1 minute ago"
      }
    }

    widget_billboard {
      title  = "transaction success rate"
      row    = 7
      column = 1
      width  = 7
      height = 3
 
      nrql_query {
        account_id = 4510907
        query      = "SELECT percentage(count(*), WHERE `error` IS false) AS TransactionSuccessRate FROM Transaction SINCE 1 day ago"
      }
    }

    widget_billboard {
      title  = "total transactions"
      row    = 1
      column = 1
      width  = 6
      height = 3
      # colors {
      #   color = "yellow"
      # }
 
      nrql_query {
        query = "FROM Transaction SELECT count(*) AS 'total transactions'"
      }
    }

    widget_bar {
      title  = "Throughput by Application"
      row    = 4
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM Transaction SELECT rate(count(*), 1 minute) AS 'Throughput' FACET appName SINCE 1 minute ago"
      }

      filter_current_dashboard = true

      colors {
        color = "#722727"
        series_overrides {
          color = "#722322"
          series_name = "App1"
        }
        series_overrides {
          color = "#236f70"
          series_name = "App2"
        }
      }
    }

    widget_line {
      title  = "Response Time by Application"
      row    = 4
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = 4510907
        query      = "FROM Transaction SELECT average(duration) AS 'Response Time' FACET appName TIMESERIES SINCE 1 hour ago"
      }

      legend_enabled = true
      ignore_time_range = false
      y_axis_left_zero = true
      y_axis_left_min = 0

      y_axis_right {
        y_axis_right_zero   = true
        y_axis_right_min    = 0
        y_axis_right_max    = 1
        y_axis_right_series = ["A", "B"]
      }

      is_label_visible = true

      threshold {
        name     = "Response Time Threshold"
        from     = 500 
        to       = 1000
        severity = "critical"
      }

      threshold {
        name     = "Response Time Warning"
        from     = 300
        to       = 499
        severity = "warning"
      }

      units {
        unit = "ms"
        series_overrides {
          unit = "ms"
          series_name = "Response Time"
        }
      }
    }

    widget_markdown {
      title  = "Dashboard Note"
      row    = 7
      column = 1
      width  = 12
      height = 3

      text = "### Helpful Links\n\n* [New Relic One](https://one.newrelic.com)\n* [Developer Portal](https://developer.newrelic.com)"
    }

    widget_line {
      title = "Overall Application Throughput"
      row = 7
      column = 1
      height = 3
      width = 4

      nrql_query {
        query = <<EOT
SELECT rate(count(*), 1 minute) FROM Transaction SINCE 1 hour ago TIMESERIES
EOT
      }
      facet_show_other_series = false
      legend_enabled = true
      ignore_time_range = false
      y_axis_left_zero = true
      y_axis_left_min = 0

      null_values {
        null_value = "default"

        series_overrides {
          null_value = "remove"
          series_name = "App1"
        }

        series_overrides {
          null_value = "zero"
          series_name = "App2"
        }

        series_overrides {
          null_value = "default"
          series_name = "App3"
        }

        series_overrides {
          null_value = "preserve"
          series_name = "App4"
        }
      }
    }
    widget_table {
            title  = " Trace ID"
            row    = 1
            column = 7
            width  = 6
            height = 3

            nrql_query {
                account_id = 4510907
                query      = "FROM Transaction SELECT traceId WHERE traceId IN ({{variablee}}) "
            }

            legend_enabled = true
            //y_axis_left_zero = true
            y_axis_left_min = 0
        }
  }

  variable {
      default_values     = ["e4f5472521f46c5ecb38891eef7dfbb8"]
      is_multi_selection = false
      item {
        title = "traceId"
        value = "0fa0a3483b350aa461788add84473fbb"
      }
      name = "variablee"
      nrql_query {
        account_ids = [4510907]
        query       = "select uniques(traceId) from Transaction"
      }
      replacement_strategy = "string"
      title                = "traceid"
      type                 = "nrql"
  }
  
  # variable {
  #   default_values     = ["value"]
  #   is_multi_selection = true
  #   item {
  #     title = "item"
  #     value = "ITEM"
  #   }
  #   name = "variable"
  #   nrql_query {
  #     account_ids = [4510907]
  #     query       = "FROM Transaction SELECT average(duration) FACET appName"
  #   }
  #   replacement_strategy = "default"
  #   title                = "title"
  #   type                 = "nrql"
  # }
  #  variable {
  #   name             = "appName"
  #   title            = "Application Name"
  #   type             = "nrql"
  #    replacement_strategy = "default"
  #   nrql_query {
  #     account_ids = [4510907]
  #     query       = "FROM Transaction SELECT uniques(appName)"
  #   }
  # }

  # variable {
  #   name             = "durationThreshold"
  #   title            = "Duration Threshold"
  #   type             = "enum"
  #   replacement_strategy = "default"
  # }
}


///////////////////////////////BROWSER DASHBOARD TERRAFORM////////////////////////////

resource "newrelic_one_dashboard" "browser_dash_new" {
  name = "browser dash new"
  page {
    name = "new relic terraform browser new"
   
    widget_line {
      title = "error rate"
      row = 4
      column = 1
      height = 3
      width = 5
      colors {
        color = "red"
      }
 
      nrql_query {
        query = "SELECT count(error) FROM Transaction WHERE appName = 'relics-browser'"
      }
    }
   
 
    widget_pie {
      title = "insights"
      row = 1
      column = 1
      width = 12
      height = 3
 
      nrql_query {
        query = "SELECT count(session) AS sessions, average(duration) AS AvgDuration, count(*) AS PageViews FROM PageView"
      }
 
    }
 
    widget_bar {
      title = "bounce rate"
      row = 4
      column = 6
      width = 7
      height = 3
 
      nrql_query {
        query = "SELECT (filter(count(session), WHERE sessionDuration < 1 * 60) / count(session)) * 100 AS BounceRate FROM PageView WHERE appName = 'relics-browser' TIMESERIES "
      }
    }
 
    widget_funnel {
      title = "funnel"
      row = 7
      column = 1
      width = 12
      height = 3
      colors {
        color = "#3366cc"
      }
 
      nrql_query {
        query = "SELECT count(session) AS sessions, average(duration) AS AvgDuration, count(*) AS PageViews,   funnel(session, where pageUrl = 'Restaurants') AS RestaurantsViews,  funnel(session, where pageUrl = 'Contact') AS ContactViews,  funnel(session, where pageUrl = 'Payment') AS PaymentViews FROM PageView"
      }
      }
     
 
 
 
      widget_bar {
      title = "conversion rate"
      row = 10
      column = 5
      width = 8
      height = 2
      nrql_query {
        query = "SELECT funnel(session, WHERE conversionEvent = true) AS ConversionRate FROM PageView"
      }
      }
 
 
 
 
      widget_bar {
      title = "average order value"
      row = 12
      column = 5
      width = 8
      height = 2
      nrql_query {
        query = "SELECT average(orderValue) AS AvgOrderValue FROM Transaction"
      }
      }
 
 
 
 
 
      widget_bar {
      title = "revenue per visitor"
      row = 14
      column = 1
      width = 12
      height = 2
      nrql_query {
        query = "SELECT sum(totalRevenue) / count(uniqueUserIds) AS RevenuePerVisitor FROM Transaction"
      }
      }
     
 
 
      widget_line {
      title = "cart abandonment rate"
      row = 16
      column = 1
      width = 12
      height = 3
      nrql_query {
        query = "SELECT percentage(count(*), WHERE cartAbandoned = true) AS CartAbandonmentRate FROM PageView"
      }
      }
 
 
 
 
      # widget_billboard {
      # title = "customer lifetime value"
      # row = 7
      # column = 1
      # width = 12
      # height = 3
      # nrql_query {
      #   query = "SELECT sum(totalRevenue) / count(distinct userId) AS CustomerLifetimeValue FROM Transaction SINCE 1 day ago"
      # }
      # }
 
 
 
      widget_billboard {
      title = "average session duration"
      row = 12
      column = 1
      width = 4
      height = 2
      nrql_query {
        query = "SELECT average(sessionDuration) AS AvgSessionDuration FROM PageView"
      }
      }
 
 
      widget_billboard {
      title = "session detals"
      row = 10
      column = 1
      width = 4
      height = 2
      nrql_query {
        query = "SELECT uniqueCount(session) AS 'Sessions' FROM PageView  FACET city , countryCode SINCE 30 days ago"
      }
      }
 
 
    }
  }