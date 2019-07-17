<?php get_header(); ?>
<div class="wrap">
  <article id="main_content">
<?php echo get_post_meta($post->ID , '1384img' ,true); ?>
<?php echo get_post_meta($post->ID , '974img' ,true); ?>
<?php echo get_post_meta($post->ID , '1623' ,true); ?>
<?php echo get_post_meta($post->ID , '1634img' ,true); ?>
<?php echo get_post_meta($post->ID , '2146img' ,true); ?>
<?php echo get_post_meta($post->ID , '2230img' ,true); ?>
<?php echo get_post_meta($post->ID , '2823img' ,true); ?>
<?php echo get_post_meta($post->ID , '2867img' ,true); ?>
<?php echo get_post_meta($post->ID , 'img' ,true); ?>

            <div id="container">
                <h1><?php the_title() ?></h1>
                    <?php
                        $posttags = get_the_tags();
                            if ($posttags) {
                            foreach($posttags as $tag) {
                            echo '<span class="category">' . $tag->name . '</span>';
                            }
                        }
                    ?>

                <div id="content"><!-- ブログ内容 -->
                    <?php while(have_posts()): the_post(); the_content(); endwhile; ?>
                </div><!-- ブログ内容 -->
        </div>
<div class="comments">
        <?php comments_template( ); ?>
</div>


<div id="recommend">
    <div align="center" style="margin:20px 0px 10px; padding: 10px; font-size: 16px; background-color: #3269AE; color: white;">人気のオススメ記事</div>
        <div style="width: 100%; border-collapse: separate; border-spacing: 10px 0;">
          <?php
            $post_ids    = [22793,22805,22859,22878,14650,25668,22879,27064,32505,14663,14659,29710];
            $count_22859 = 0;
            foreach($post_ids as $post_id):
            if($post_id == 22859 and $count_22859 == 0){
                $title        = 'アルブチンの2倍の美白効果！10万本突破の「シミ対策」美容液が凄い！';
                $img_src      = 'https://navivi.site/wp-content/uploads/2018/10/14-1.jpg';
                $count_22859 += 1;
            }else{
                $title = get_post( $post_id )->post_title;
                $img_src = get_the_post_thumbnail_url( $post_id, 'midium' );
            }
            $link  = get_permalink( $post_id );
            $class = "article-{$post_id}";
          ?>
          <?php print '
            <div class="'.$class.'" style="width: 30%; height: auto; display: table-cell;><a href="'.$link.'"><img style="width: 100%; height: auto;" src="'.$img_src.'"></a></div>
            <div class="'.$class.'" style="font-size: 15px; display: table-cell; vertical-align: middle;"><a href="'.$link.'" class="adlink">'.$title.'</a></div>
            <hr>';
          ?>
    <?php endforeach; ?>
</div>

        <!-- display banner -->
        <!-- Adx -->
        <!-- list ads -->
        <div id='div-gpt-ad-1537851146573-0'>
            <script>googletag.cmd.push(function() { googletag.display('div-gpt-ad-1537851146573-0'); });</script>
        </div>

        <div id='div-gpt-ad-1537855919225-0'>
            <script>googletag.cmd.push(function() { googletag.display('div-gpt-ad-1537855919225-0'); });</script>
        </div>

        <div id='div-gpt-ad-1537856612998-0'>
            <script>googletag.cmd.push(function() { googletag.display('div-gpt-ad-1537856612998-0'); });</script>
        </div>
        <!-- list ads -->

        <!-- rectangle banner -->
        <div id='div-gpt-ad-1537844617512-0' style="text-align:center;">
            <script>googletag.cmd.push(function() { googletag.display('div-gpt-ad-1537844617512-0'); });</script>
        </div>
        <!-- rectangle banner -->
        <!-- Adx -->

        <!-- own banner -->
        <script src="https://n.navivi.site/js/banner.js"></script>
        <!-- own banner -->
        <!-- display banner -->
    </div>
  </article>

<?php get_sidebar(); ?>
</div>
<?php get_footer(); ?>
