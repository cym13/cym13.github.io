<!DOCTYPE HTML>
<html>
  <head> %(head)s
    <link rel="stylesheet" type="text/css" href="../style/base.css"/>
    <link rel="stylesheet" type="text/css" href="../style/pygments.css"/>
    <link rel="stylesheet" type="text/css" href="../style/math.css"/>

    <link rel="alternate" type="application/rss+xml" title="Breakpoint RSS" href="../rss.xml"/>
    <link rel="alternate" type="application/rss+xml" title="Stream of Consciousness RSS" href="../soc_rss.xml"/>
    <!--
        The RSS icon used in this page is derived from https://www.flaticon.com/free-icon/rss-feed-symbol_110
        made by https://www.flaticon.com/authors/freepik. Thank you for providing quality, open work.
    -->
  </head>
  <body>
    <header class="site-header">
      <div class="site-title">
        <div class="title-text">
          <h1>Breakpoint</h1>
          <h2>Stepping through security</h2>
        </div>
        <img src="../image/tomoko1.png"/>
      </div>
      <div class="wrap">

        <ul>
          <li>
              <a href="../index.html">Index</a>
              <a href="../rss.xml">
                  <img src="../image/rss.png" />
              </a>
          </li>
          <li><a href="https://github.com/cym13">Github</a></li>
          <li><a href="../soc.html">SoC</a>
              <a href="../soc_rss.xml">
                  <img src="../image/rss.png" />
              </a>
          </li>
          <li><a href="../about.html">About</a></li>
        </ul>
      </div>
    </header>

    <div class="content">
      %(body)s
    </div>
    <footer "class"="site-footer">
      <div "class"="publication_date">
        First published: »PUB_DATE«
      </div>
    </footer>
  </body>
</html>
