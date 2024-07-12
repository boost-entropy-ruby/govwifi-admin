describe "Guidance after sign in", type: :feature do
  let(:user) { create(:user, :with_organisation) }

  before { sign_in_user user }

  context "without locations" do
    before { visit root_path }

    it "displays information about GovWifi servers" do
      expect(page).to have_selector("h2", text: "GovWifi servers")
    end
  end

  context "with locations" do
    before do
      create(:location, organisation: user.organisations.first)
      visit root_path
    end

    it_behaves_like "shows the settings page"

    context "with radius IPs in env-vars" do
      let(:radius_ip_1) { "111.111.111.111" }
      let(:radius_ip_2) { "121.121.121.121" }
      let(:radius_ip_3) { "131.131.131.131" }
      let(:radius_ip_4) { "141.141.141.141" }

      before do
        ENV["LONDON_RADIUS_IPS"] = "#{radius_ip_1},#{radius_ip_2}"
        ENV["DUBLIN_RADIUS_IPS"] = "#{radius_ip_3},#{radius_ip_4}"
      end

      it "displays the London IPs" do
        ips = page.all(:css, "#london-radius-ips li").map(&:text)
        expect(ips).to match_array([radius_ip_1, radius_ip_2])
      end

      it "displays the Dublin IPs" do
        ips = page.all(:css, "#dublin-radius-ips li").map(&:text)
        expect(ips).to match_array([radius_ip_3, radius_ip_4])
      end
    end
  end
end
