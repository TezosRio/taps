

        $(document).ready(function () {
            $('#sidebarCollapse').on('click', function () {
                $('#sidebar').toggleClass('active');
                $(this).toggleClass('active');
            });
         
            /* Hover Menu */
            $('a[name=setup]').css('color','#c8b08b');

            $('a:not([name=reset])').on('click', function() 
            {
                $('a').css('color', '#fff');
                $(this).css('color', '#c8b08b');  
            })

            $('a[name=reset]').on('click', function() 
            {
                $('a').css('color', '#fff');
                $('a[name=setup]').css('color','#c8b08b');
            })
           
        });
