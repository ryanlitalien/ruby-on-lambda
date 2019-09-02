<template>
  <div class="container">
    <div class="header clearfix">
      <!--<nav>-->
      <!--<ul class="nav nav-pills pull-right">-->
      <!--<li role="presentation" class="active">Home</li>-->
      <!--<li role="presentation"><a href="#about">About</a></li>-->
      <!--</ul>-->
      <!--</nav>-->
      <h3 class="text-muted">
        <!--      <a href="index.html"><img alt="quicktrack header" src="images/logo_transparent.png" width="200px" /></a>-->
        <a href="index.html">QuickTrack</a>
      </h3>
    </div>

    <div class="jumbotron text-center">
      <h1>Easily track food</h1>
      <h4>Just a click away.</h4>
      <p class="lead">
        Easily send your breakfast/lunch/dinner to your coach.
      </p>
      <div id="search-box" class="hero">
        <form class="">
          <div class="row">
            <div class="col-md-12">
              <div class="input-group mb-3">
                <input
                  id="numberSearch"
                  v-model="phoneNumber"
                  type="text"
                  class="form-control"
                  autofocus="autofocus"
                  placeholder="603-555-1234"
                  aria-label="Phone number lookup"
                  aria-describedby="search-submit"
                >
                <div class="input-group-append">
                  <button
                    id="search-submit"
                    class="btn btn-primary"
                    type="button"
                    @click="search"
                  >
                    <i class="fas fa-search" />
                  </button>
                </div>
              </div>
              <a
                id="sms-button"
                href="sms://+18573052778"
                role="button"
                class="btn btn-primary btn-sm btn-block"
              >or start by sending your name via SMS 📱</a>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div class="row" style="margin-bottom: 10px;">
      <div class="col-lg-12 text-center">
        <div v-if="loading">
          <h1 id="h1-title">
            Results will show here.
          </h1>
        </div>

        <div v-else-if="foods.length === 0">
          <h1>
            No results found.
          </h1>
        </div>

        <div v-else id="food-content">
          <food v-for="food in foods" :key="food.key" :food="food" />
        </div>
      </div>
    </div>

    <footer class="footer">
      <p>This is a fun app I made to easily track my food.</p>
      <p>
        This project is open source, so open up a
        <a href="https://github.com/ryanlitalien/ruby-on-lambda" target="_blank">pull request or issue</a>!
      </p>
    </footer>
  </div>
</template>

<script>
import Food from "~/components/Food.vue";
import { mapGetters } from "vuex";

export default {
  watchQuery: ["page"],
  components: { Food },
  props: {
    isLoading: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      loading: this.isLoading,
      phoneNumber: "",
      errors: []
    };
  },
  computed: mapGetters({
    foods: "foodsList"
  }),
  watch: {
    // call again the method if the route changes
    $route: "fetchData"
  },
  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchData();
  },
  methods: {
    search() {
      this.fetchData();
    },
    fetchData() {
      this.loading = true;
      let number = this.phoneNumber;
      if(number.length === 0) {
        number = this.$route.params.number;
      }

      this.$store.dispatch("GET_FOODS", { number })
        .then(() => {
          this.loading = false;
        })
        .catch(error => {
          this.loading = true;
          console.log(error)
        });
    }
  }
}
</script>

<style lang="scss"></style>
