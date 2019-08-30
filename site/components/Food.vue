<template>
  <div class="col-lg-3 col-md-3 col-sm-3 text-center panel">
    <h4>{{food.message}}</h4>
    <div>
      <img :src="food.public_url" class="responsive-fit effect1" />
    </div>
<!--    <h4>{{friendlyLastModified}}</h4>-->
    <h4>{{food.last_modified}}</h4>
  </div>
</template>

<script>
  export default {
    name: 'food',
    props: {
      food: {
        type: Object,
        required: true
      }
    },
  }
</script>

<style>
  .effect1 {
    -webkit-box-shadow: 0 10px 6px -6px #777;
    -moz-box-shadow: 0 10px 6px -6px #777;
    box-shadow: 0 10px 6px -6px #777;
  }
  .responsive-fit {
    width: 100px;
    height: 100px;
    object-fit: cover;
  }
</style>
